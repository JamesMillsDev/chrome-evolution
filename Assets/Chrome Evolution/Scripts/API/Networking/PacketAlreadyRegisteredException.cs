using Type = System.Type;

namespace ChromeEvo.API.Networking
{
	public class PacketAlreadyRegisteredException : System.Exception
	{
		public PacketAlreadyRegisteredException(Type _packetType) : base(string.Format("Packet [{0}] is already registered!", _packetType.ToString()))
		{
			
		}
	}
}