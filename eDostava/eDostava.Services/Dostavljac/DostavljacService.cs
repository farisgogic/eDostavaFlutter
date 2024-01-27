﻿using AutoMapper;
using eDostava.Model;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.Dostavljac
{
    public class DostavljacService : BaseCRUDService<Model.Dostavljac, Database.Dostavljac, DostavljacSearchObject, DostavljacInsertRequest, DostavljacUpdateRequest>, IDostavljacService
    {
        public DostavljacService(DostavaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override Model.Dostavljac Update(int id, DostavljacUpdateRequest update)
        {
            var kupac = context.Kupci.Find(id);

            if (kupac == null)
            {
                return null;
            }

            if (!string.IsNullOrEmpty(update.Lozinka) && update.Lozinka != update.LozinkaPotvrda)
            {
                throw new UserException("Lozinke se ne poklapaju!");
            }

            if (update.Lozinka == update.LozinkaPotvrda && !string.IsNullOrEmpty(update.Lozinka))
            {
                var salt = GenerateSalt();
                kupac.LozinkaSalt = salt;
                kupac.LozinkaHash = GenerateHash(salt, update.Lozinka);
            }

            mapper.Map(update, kupac);
            context.SaveChanges();

            return mapper.Map<Model.Dostavljac>(kupac);
        }

        public override void BeforeInsert(DostavljacInsertRequest insert, Database.Dostavljac entity)
        {
            var salt = GenerateSalt();
            entity.LozinkaSalt = salt;
            entity.LozinkaHash = GenerateHash(salt, insert.Lozinka);
            base.BeforeInsert(insert, entity);
        }


        public override Model.Dostavljac Insert(DostavljacInsertRequest insert)
        {
            if (insert.Lozinka != insert.LozinkaPotvrda)
            {
                throw new UserException("Lozinke se ne poklapaju!");
            }
            var entity = base.Insert(insert);

            foreach (var ulogId in insert.UlogeIdList)
            {
                Database.KorisnikUloga korisnikUloga = new Database.KorisnikUloga();
                korisnikUloga.UlogaId = ulogId;
                korisnikUloga.DostavljacId = entity.DostavljacId;
                korisnikUloga.DatumPromjene = DateTime.Now;

                context.KorisnikUloga.Add(korisnikUloga);
            }

            context.SaveChanges();
            return entity;
        }

        public static string GenerateSalt()
        {
            RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
            var byteArray = new byte[16];
            provider.GetBytes(byteArray);


            return Convert.ToBase64String(byteArray);
        }
        public static string GenerateHash(string salt, string password)
        {
            try
            {
                byte[] src = Convert.FromBase64String(salt);
                byte[] bytes = Encoding.Unicode.GetBytes(password);
                byte[] dst = new byte[src.Length + bytes.Length];

                System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
                System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

                HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
                byte[] inArray = algorithm.ComputeHash(dst);
                return Convert.ToBase64String(inArray);
            }
            catch (FormatException ex)
            {
                Console.WriteLine("Error: " + ex.Message);
                return null;
            }
        }

        public Model.Dostavljac Login(string username, string password)
        {
            var entity = context.Dostavljac.Include("KorisnikUloga.Uloga").FirstOrDefault(x => x.KorisnickoIme == username);
            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.LozinkaSalt, password);
            if (hash != entity.LozinkaHash)
            {
                return null;
            }

            return mapper.Map<Model.Dostavljac>(entity);
        }

    }
}
