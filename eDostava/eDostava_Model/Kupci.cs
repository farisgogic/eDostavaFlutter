using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Model
{
    public partial class Kupci
    {
        public int KupacId { get; set; }
        public string Ime { get; set; } = null!;
        public string Prezime { get; set; } = null!;
        public string Adresa { get; set; } = null!;

        [EmailAddress]
        public string Email { get; set; } = null!;
        public string KorisnickoIme { get; set; } = null!;


        public ICollection<KorisnikUloga> KorisnikUloga { get; set; }
        public string UlogaIme => string.Join(" ", KorisnikUloga?.Select(x => x.Uloga?.Naziv)?.ToList());
    }
}
