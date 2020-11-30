using Type = System.Type;

namespace ChromeEvo.API.Networking
{
	public class PacketNotRegisteredException : System.Exception
	{
		public PacketNotRegisteredException(Type _packetType) : base(string.Format("Packet [{0}] is not registered!", _packetType.ToString()))
		{

		}
	}
}