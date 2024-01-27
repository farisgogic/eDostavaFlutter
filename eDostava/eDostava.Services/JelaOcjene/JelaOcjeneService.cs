using AutoMapper;
using eDostava.Model;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Database;
using eDostava.Services.Jelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.JelaOcjene
{
    public class JelaOcjeneService : BaseCRUDService<Model.JelaOcjene, Database.JelaOcjene, JelaOcjeneSearchObject, JelaOcjeneUpsertRequest, JelaOcjeneUpsertRequest>, IJelaOcjeneService
    {
        private readonly JeloService jeloService;

        public JelaOcjeneService(DostavaContext context, IMapper mapper, JeloService jeloService) : base(context, mapper)
        {
            this.jeloService = jeloService;
        }


        public override Model.JelaOcjene Insert(JelaOcjeneUpsertRequest insert)
        {
            var result = base.Insert(insert);
            jeloService.UpdateAverageRatingForJelo(insert.JeloId);


            return result;
        }

        public override Model.JelaOcjene Update(int id, JelaOcjeneUpsertRequest update)
        {
            var result = base.Update(id, update);
            jeloService.UpdateAverageRatingForJelo(update.JeloId);


            return result;
        }


        public override IQueryable<Database.JelaOcjene> AddFilter(IQueryable<Database.JelaOcjene> query, JelaOcjeneSearchObject search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (search?.jeloId != null)
            {
                filteredQuery = filteredQuery.Where(j => j.JeloId == search.jeloId);
            }
            if (search?.kupacId != null)
            {
                filteredQuery = filteredQuery.Where(j => j.KupacId == search.kupacId);
            }

            return filteredQuery; 
        }
    }
}
