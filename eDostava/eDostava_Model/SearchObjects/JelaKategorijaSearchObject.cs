using System;
using System.Collections.Generic;
using System.Text;

namespace eDostava.Model.SearchObjects
{
    public class JelaKategorijaSearchObject: BaseSearchObject
    {
        public int? jeloId { get; set; }
        public int? kategorijaId { get; set; }
    }
}
