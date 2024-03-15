using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Narudzba;
using Microsoft.AspNetCore.Authorization;

namespace eDostava.Controllers
{
    [AllowAnonymous]
    public class NarudzbaController : BaseCRUDController<Model.Narudzba, NarudzbaSearchObject, NarudzbaInsertRequest, NarudzbaUpdateRequest>
    {
        public NarudzbaController(INarudzbaService service, WebSocketHandler webSocketHandler)
            : base(service, webSocketHandler)
        { }
    }
}
