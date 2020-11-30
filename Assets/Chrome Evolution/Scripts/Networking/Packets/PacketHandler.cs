namespace ChromeEvo.Networking.Packets
{
    public class PacketHandler : API.Networking.PacketHandler
    {
        protected override void RegisterPackets()
        {
            RegisterPacket<PacketReadyPlayer>();
            RegisterPacket<PacketUpdatePlayerCustomisation>();
            RegisterPacket<PacketStartGame>();
            RegisterPacket<PacketDamagePlayer>();
        }
    }
}