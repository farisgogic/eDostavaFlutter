﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Model.SearchObjects
{
    public class KorisnikSearchObject : BaseSearchObject
    {
        public string? korisnickoIme { get; set; }
        public bool IncludeRoles { get; set; }

    }
}
