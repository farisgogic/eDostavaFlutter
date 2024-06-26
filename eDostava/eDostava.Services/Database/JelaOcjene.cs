﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.Database
{
    public partial class JelaOcjene
    {
        public int JelaOcjeneId { get; set; }
        public float Ocjena { get; set; }
        public string? Komentar { get; set; }
        public int JeloId { get; set; }
        public int KupacId { get; set; }

        public virtual Jelo Jelo { get; set; } = null!;
        public virtual Kupci Kupci{ get; set; } = null!;

    }
}
