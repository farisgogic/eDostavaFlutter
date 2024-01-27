using System.Collections.Concurrent;
using System.Net.WebSockets;

namespace eDostava
{
    public class WebSocketCollection : ConcurrentBag<WebSocket>
    {
    }
}
