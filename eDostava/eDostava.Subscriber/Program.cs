using EasyNetQ;
using eDostava.Model;

using (var bus = RabbitHutch.CreateBus("host=localhost"))
{
    bus.PubSub.Subscribe<Narudzba>("test", HandleTextMessage);
    Console.WriteLine("Listening for messages. Hit <return> to quit.");
    Console.ReadLine();
}

void HandleTextMessage(Narudzba narudzba)
{
    Console.WriteLine($"Narudzba broj {narudzba?.BrojNarudzbe} je zaprimljena!");

}