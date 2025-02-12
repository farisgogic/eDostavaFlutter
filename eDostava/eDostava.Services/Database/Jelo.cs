﻿using eDostava.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.Database
{
    public partial class Jelo
    {
        public Jelo()
        {
            JeloKategorijas = new HashSet<JeloKategorija>();
            JelaOcjene = new HashSet<JelaOcjene>();
            Favoriti = new HashSet<Favoriti>();
            NarudzbaStavke = new HashSet<NarudzbaStavke>();
        }

        public int JeloId { get; set; }
        public string Naziv { get; set; }
        public double Cijena { get; set; }
        public string? Opis { get; set; }
        public byte[]? Slika { get; set; }

        [Range(1,5)]
        public decimal? Ocjena { get; set; }

        public bool Arhivirano { get; set; }

        public virtual ICollection<JeloKategorija> JeloKategorijas { get; set; }

        public int RestoranId { get; set; }
        public Restoran Restoran { get; set; }
        public virtual ICollection<JelaOcjene> JelaOcjene { get; set; }
        public virtual ICollection<Favoriti> Favoriti { get; set; }
        public virtual ICollection<NarudzbaStavke> NarudzbaStavke { get; set; }
    }
}
