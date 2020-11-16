using UnityEngine;

using Mirror;

namespace ChromeEvo.Networking
{
    public class ChromeNetworkManager : NetworkManager
    {
        public bool IsHost { get; set; } = false;

        public override void OnStartHost()
        {
            base.OnStartHost();

            IsHost = true;
        }
    }
}