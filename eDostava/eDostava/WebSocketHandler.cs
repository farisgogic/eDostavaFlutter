using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace eDostava
{
    public class WebSocketHandler
    {
        private static readonly WebSocketCollection _sockets = new WebSocketCollection();

        public WebSocketHandler(HttpClient httpClient)
        {
        }

        public async Task Handle(WebSocket webSocket)
        {
            _sockets.Add(webSocket);

            var buffer = new byte[4096];
            WebSocketReceiveResult result;

            do
            {
                try
                {
                    result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

                    if (result.MessageType == WebSocketMessageType.Text)
                    {
                        var message = Encoding.UTF8.GetString(buffer, 0, result.Count);
                    }
                }
                finally
                {
                    _sockets.TryTake(out _);
                }

            } while (!result.CloseStatus.HasValue);

            _sockets.TryTake(out _);
        }

        public async Task SendToAllAsync(string message)
        {
            var buffer = new ArraySegment<byte>(Encoding.UTF8.GetBytes(message));

            foreach (var socket in _sockets)
            {
                if (socket.State == WebSocketState.Open)
                {
                    await socket.SendAsync(buffer, WebSocketMessageType.Text, true, CancellationToken.None);
                }
            }
        }
    }



}
