using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.JelaKategorija
{
    public interface IJelaKategorijaService : ICRUDService<Model.JeloKategorija, JelaKategorijaSearchObject, JelaKategorijaUpsertRequest, JelaKategorijaUpsertRequest>
    {
    }
}
