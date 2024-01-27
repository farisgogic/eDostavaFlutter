using AutoMapper;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.JelaKategorija
{
    public class JelaKategorijaService : BaseCRUDService<Model.JeloKategorija, Database.JeloKategorija, JelaKategorijaSearchObject, JelaKategorijaUpsertRequest, JelaKategorijaUpsertRequest>, IJelaKategorijaService
    {
        public JelaKategorijaService(DostavaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.JeloKategorija> AddFilter(IQueryable<Database.JeloKategorija> query, JelaKategorijaSearchObject search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (search?.jeloId != null)
            {
                filteredQuery = filteredQuery.Where(j => j.JeloId == search.jeloId);
            }
            if (search?.kategorijaId != null)
            {
                filteredQuery = filteredQuery.Where(j => j.KategorijaId == search.kategorijaId);
            }

            return filteredQuery; 
        }
    }
}
