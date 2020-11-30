using Serializable = System.SerializableAttribute;

namespace ChromeEvo.API.Networking
{
	[Serializable]
	public abstract class Packet
	{
		public abstract void Handle();
		public abstract void Serialize(PacketBuffer _buffer);
		public abstract void Deserialize(PacketBuffer _buffer);
	}
}
