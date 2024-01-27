using eDostava.Model;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Database;
using eDostava.Services.JelaKategorija;
using eDostava.Services.Jelo;
using eDostava.Services.Review;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace eDostava.Controllers
{
    [AllowAnonymous]
    public class JelaKategorijaController : BaseCRUDController<Model.JeloKategorija, JelaKategorijaSearchObject, JelaKategorijaUpsertRequest, JelaKategorijaUpsertRequest>
    {
        public IJelaKategorijaService JelaKategorijaService { get; set; }
        public JelaKategorijaController(IJelaKategorijaService jelaKategorijaService) : base(jelaKategorijaService)
        {
            JelaKategorijaService = jelaKategorijaService;
        }
    }
}
