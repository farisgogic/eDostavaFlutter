using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Model.Request
{
    public class LoginResponseKorisnik
    {
        public Model.Korisnik Korisnik { get; set; }
        public string Token { get; set; }
    }
}
