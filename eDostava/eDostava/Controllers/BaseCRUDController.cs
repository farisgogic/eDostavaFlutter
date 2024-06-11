using eDostava.Services;
using eDostava.Services.Uloga;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eDostava.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    
    public class BaseCRUDController<T, TSearch, TInsert, TUpdate> : BaseController<T, TSearch> where T : class where TSearch : class where TInsert : class where TUpdate : class
    {
        private readonly WebSocketHandler _webSocketHandler;

        public BaseCRUDController(ICRUDService<T, TSearch, TInsert, TUpdate> service, WebSocketHandler webSocketHandler = null) : base(service)
        {
            _webSocketHandler = webSocketHandler;
        }


        [HttpPost]
        public virtual T Insert([FromBody] TInsert insert)
        {
            var result = ((ICRUDService<T, TSearch, TInsert, TUpdate>)this.Service).Insert(insert);
            if (_webSocketHandler != null)
            {
                _webSocketHandler.SendToAllAsync("Novi podatak je dodan!");
            }
            return result;
        }


        [HttpPut("{id}")]
        [ApiExplorerSettings(IgnoreApi = false)]
        public virtual T Update(int id, [FromBody]TUpdate update)
        {
            var result = ((ICRUDService<T, TSearch, TInsert, TUpdate>)this.Service).Update(id, update);

            if (_webSocketHandler != null)
            {
                _webSocketHandler.SendToAllAsync("Podatak je editovan!");
            }

            return result;
        }

        [HttpDelete("{id}")]
        public virtual IActionResult Delete(int id)
        {
            try
            {
                ((ICRUDService<T, TSearch, TInsert, TUpdate>)this.Service).Delete(id);

                if (_webSocketHandler != null)
                {
                    _webSocketHandler.SendToAllAsync("Podatak je izbrisan!");
                }

                return Ok();
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal Server Error");
            }
        }

    }
}
