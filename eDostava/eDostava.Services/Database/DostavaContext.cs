﻿using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.Database
{
    public partial class DostavaContext : DbContext
    {
        public DostavaContext()
        {
        }
        public DostavaContext(DbContextOptions options) : base(options)
        {
        }


        public virtual DbSet<Korisnik> Korisnik { get; set; }
        public virtual DbSet<Kupci> Kupci { get; set; }
        public virtual DbSet<Dostavljac> Dostavljac { get; set; }
        public virtual DbSet<Jelo> Jelo { get; set; }
        public virtual DbSet<Kategorija> Kategorija { get; set; }
        public virtual DbSet<KorisnikUloga> KorisnikUloga { get; set; }
        public virtual DbSet<Recenzija> Recenzija { get; set; }
        public virtual DbSet<Narudzba> Narudzba { get; set; }
        public virtual DbSet<NarudzbaStavke> NarudzbaStavke { get; set; }
        public virtual DbSet<Favoriti> Favoriti { get; set; }
        public virtual DbSet<Restoran> Restoran { get; set; }
        public virtual DbSet<Uloga> Uloga { get; set; }
        public virtual DbSet<JeloKategorija> JeloKategorija { get; set; }
        public virtual DbSet<JelaOcjene> JelaOcjene { get; set; }


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Data Source=localhost, 1401; Initial Catalog=Dostava; user=sa; Password=Konjic1981; TrustServerCertificate=True");

            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Korisnik>()
                .HasOne(k => k.Restoran)
                .WithOne(r => r.Korisnik)
                .HasForeignKey<Restoran>(r => r.KorisnikId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<JeloKategorija>()
                .HasOne(jk => jk.Kategorija)
                .WithMany(k => k.JeloKategorijas)
                .HasForeignKey(jk => jk.KategorijaId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<JelaOcjene>()
               .HasOne(j => j.Kupci)
               .WithMany(k => k.JelaOcjene)
               .HasForeignKey(j => j.KupacId)
               .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Recenzija>()
               .HasOne(j => j.Kupci)
               .WithMany(k => k.Recenzija)
               .HasForeignKey(j => j.KupacId)
               .OnDelete(DeleteBehavior.Cascade);


            modelBuilder.Entity<Favoriti>()
                .HasOne(f => f.Jelo)
                .WithMany(j => j.Favoriti)
                .HasForeignKey(f => f.JeloId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Favoriti>()
                .HasOne(f => f.Restoran)
                .WithMany(r => r.Favoriti)
                .HasForeignKey(f => f.RestoranId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<JeloKategorija>()
                .HasOne(jk => jk.Jelo)
                .WithMany(j => j.JeloKategorijas)
                .HasForeignKey(jk => jk.JeloId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<JeloKategorija>()
                .HasOne(jk => jk.Kategorija)
                .WithMany(k => k.JeloKategorijas)
                .HasForeignKey(jk => jk.KategorijaId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<NarudzbaStavke>()
                .HasOne(ns => ns.Narudzba)
                .WithMany(n => n.NarudzbaStavke)
                .HasForeignKey(ns => ns.NarudzbaId)
                .OnDelete(DeleteBehavior.Restrict); 

            modelBuilder.Entity<NarudzbaStavke>()
                .HasOne(ns => ns.Jelo)
                .WithMany(j => j.NarudzbaStavke)
                .HasForeignKey(ns => ns.JeloId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Narudzba>()
                .HasOne(n => n.Kupac)
                .WithMany()
                .HasForeignKey(n => n.KupacId)
                .OnDelete(DeleteBehavior.Restrict);


            onModelCreatingPartial(modelBuilder);
        }

        partial void onModelCreatingPartial(ModelBuilder modelBuilder);

    }
}
