using Mirror;

namespace ChromeEvo.Networking
{
    public class ChromeNetworkManager : NetworkManager
    {
        public bool IsHost { get; private set; } = false;

        public override void OnStartHost() => IsHost = true;
    }
}