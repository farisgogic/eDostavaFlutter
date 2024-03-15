using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eDostava.Services.RabbitMQ
{
    public interface IMailProducer
    {
        public void SendMessage<T>(T message);
    }
}
