using eDostava.Model;
using eDostava.Model.Request;
using eDostava.Model.SearchObjects;
using eDostava.Services.Dostavljac;
using eDostava.Services;
using eDostava.Services.Services.Korisnik;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eDostava.Controllers
{
    [Authorize]

    public class KorisnikController : BaseCRUDController<Model.Korisnik, KorisnikSearchObject, KorisniciInsertRequest, KorisniciUpdateRequest>
    {
        private readonly IKorisnikService korisnikService;
        private readonly ITokenService tokenService;

        public KorisnikController(IKorisnikService korisnikService, ITokenService tokenService) :base(korisnikService)
        {
            this.korisnikService = korisnikService;
            this.tokenService = tokenService;
        }

        [AllowAnonymous]
        public override Korisnik Insert([FromBody] KorisniciInsertRequest insert)
        {
            return base.Insert(insert);
        }

        public override Korisnik Update(int id, [FromBody] KorisniciUpdateRequest update)
        {
            return base.Update(id, update);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public ActionResult<Model.Korisnik> Login([FromBody] LoginRequest loginRequest)
        {
            var korisnik = korisnikService.Login(loginRequest.Username, loginRequest.Password);
            if (korisnik == null)
            {
                return Unauthorized();
            }

            var token = tokenService.GenerateTokenKorisnik(korisnik);

            var response = new LoginResponseKorisnik()
            {
                Korisnik = korisnik,
                Token = token
            };

            return Ok(response);
        }

        [HttpPost("logout")]
        public IActionResult Logout()
        {
                return Ok();
            
        }
    }
}
