using AutoMapper;
using EasyNetQ;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Database;
using Microsoft.EntityFrameworkCore;
using RabbitMQ.Client;
using System.Net.Mail;
using System.Net;
using System.Text;
using eDostava.Model;
using Newtonsoft.Json;
using eDostava.Services.RabbitMQ;

namespace eDostava.Services.Narudzba
{
    public class NarudzbeService : BaseCRUDService<Model.Narudzba, Database.Narudzba, NarudzbaSearchObject, NarudzbaInsertRequest, NarudzbaUpdateRequest>, INarudzbaService
    {
        private readonly IMailProducer _rabbitMQProducer;

        public NarudzbeService(DostavaContext context, IMapper mapper, IMailProducer rabbitMQProducer) : base(context, mapper)
        {
            _rabbitMQProducer = rabbitMQProducer;
        }


        public override IQueryable<Database.Narudzba> AddFilter(IQueryable<Database.Narudzba> query, NarudzbaSearchObject search = null)
        {
            if (search?.stanje != null)
            {
                StanjeNarudzbe stanjeEnum = (StanjeNarudzbe)search.stanje.Value;
                query = query.Where(j => j.Stanje == stanjeEnum);
            }
            if (search?.RestoranId != null)
            {
                query = query.Where(j => j.RestoranId == search.RestoranId);
            }
            if (!string.IsNullOrEmpty(search?.BrojNarudzbe))
            {
                query = query.Where(x => x.BrojNarudzbe.StartsWith(search.BrojNarudzbe));
            }
            if (search?.kupacId != null)
            {
                query = query.Where(j => j.KupacId == search.kupacId);
            }
            return query;
        }


        public override void BeforeInsert(NarudzbaInsertRequest insert, Database.Narudzba entity)
        {
            entity.Datum = DateTime.Now;

            int brojNarudzbiZaRestoran = context.Narudzba.Count(n => n.RestoranId == insert.RestoranId);
            entity.BrojNarudzbe = (brojNarudzbiZaRestoran + 1).ToString();

            entity.Stanje = Database.StanjeNarudzbe.NaCekanju;

            base.BeforeInsert(insert, entity);
        }
        public class OrderConfirmationEvent
        {
            public int OrderId { get; }
            public string UserEmail { get; }

            public OrderConfirmationEvent(int orderId, string userEmail)
            {
                OrderId = orderId;
                UserEmail = userEmail;
            }
        }

        public class EmailModel
        {
            public string Sender { get; set; }
            public string Recipient { get; set; }
            public string Subject { get; set; }
            public string Content { get; set; }

        }

        public override Model.Narudzba Insert(NarudzbaInsertRequest insert)
        {
            var result = base.Insert(insert);
            foreach (var item in insert.Items)
            {
                Database.NarudzbaStavke dbItem = new NarudzbaStavke();
                dbItem.NarudzbaId = result.NarudzbaId;
                dbItem.JeloId = item.JeloId;
                dbItem.Kolicina = item.Kolicina;


                context.NarudzbaStavke.Add(dbItem);
            }

            context.SaveChanges();

            var mappedEntity = result;
            var kupac = context.Kupci.Find(mappedEntity.KupacId);

            var emailModel = new EmailModel
            {
                Sender = "edostava9@gmail.com",
                Recipient = kupac.Email,
                Subject = "Nova narudžba",
                Content = $@"
                        Poštovani,
                        Vaša narudžba broj je zaprimljena.
                        Broj narudžbe je {mappedEntity.BrojNarudzbe}.
                        Hvala Vam na povjerenju!
                ",
            };

            _rabbitMQProducer.SendMessage(emailModel);
            Thread.Sleep(TimeSpan.FromSeconds(5));


            return mappedEntity;
        }
        public override Model.Narudzba GetById(int id)
        {
            var dbNarudzba = context.Narudzba
                .Include(n => n.NarudzbaStavke)
                .ThenInclude(s => s.Jelo)
                .SingleOrDefault(n => n.NarudzbaId == id);

            var modelNarudzba = mapper.Map<Model.Narudzba>(dbNarudzba);

            foreach (var stavka in modelNarudzba.NarudzbaStavke)
            {
                var jelo = context.Jelo.Find(stavka.JeloId);
                stavka.Naziv = jelo.Naziv;
                stavka.Cijena = jelo.Cijena;
                stavka.IzracunajCijenu();
            }

            return modelNarudzba;
        }

        public override IEnumerable<Model.Narudzba> Get(NarudzbaSearchObject search = null)
        {
            var entity = context.Narudzba
                .Include(n => n.NarudzbaStavke)
                .ThenInclude(s => s.Jelo)
                .AsQueryable();

            entity = AddFilter(entity, search);
            entity = AddInclude(entity, search);

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                entity = entity.Take(search.PageSize.Value).Skip(search.Page.Value * search.PageSize.Value);
            }

            var list = mapper.Map<IEnumerable<Model.Narudzba>>(entity).ToList();

            foreach (var narudzba in list)
            {
                foreach (var stavka in narudzba.NarudzbaStavke)
                {
                    var jelo = context.Jelo.Find(stavka.JeloId);
                    stavka.Naziv = jelo.Naziv;
                    stavka.Cijena = jelo.Cijena;
                    stavka.IzracunajCijenu();
                }
            }

            return list;
        }

        public override Model.Narudzba Update(int id, NarudzbaUpdateRequest update)
        {
            var entity = context.Narudzba.Find(id);
            entity.Stanje = (StanjeNarudzbe)update.StatusNarudzbeId;
            entity.DostavljacId = update.DostavljacId;

            context.SaveChanges();
            return mapper.Map<Model.Narudzba>(entity);
        }


    }

}
