using eDostava.Model;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services;
using eDostava.Services.Jelo;
using eDostava.Services.Services.Korisnik;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eDostava.Controllers
{
     [AllowAnonymous]
    public class JeloController : BaseCRUDController<Model.Jelo, JeloSearchObject, JeloUpsertRequest, JeloUpsertRequest>
    {
        private readonly IJeloService jeloService;

        public JeloController(IJeloService jeloService, WebSocketHandler webSocketHandler) : base(jeloService, webSocketHandler)
        {
            this.jeloService = jeloService;
        }


        [AllowAnonymous]
        [HttpGet("{kupacId}/{restoranId}/Recommend")]
        public List<Jelo> Recommend(int kupacId, int restoranId)
        {
            var result = jeloService.GetRecommendedJela(kupacId, restoranId);

            return result;
        }

        [HttpPut("{id}/UpdateArhivirano")]
        public IActionResult UpdateArhivirano(int id, [FromBody] JeloUpsertRequest update)
        {
            var jelo = jeloService.UpdateArhivirano(id, update);

            if (jelo != null)
            {
                return Ok(jelo);
            }

            return NotFound();
        }

    }
}
 