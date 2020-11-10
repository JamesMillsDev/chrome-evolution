using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Mirror;

namespace ChromeEvo.Player
{
    [RequireComponent(typeof(ChromePlayer))]
    public class ChromePlayerNet : NetworkBehaviour
    {
        private ChromePlayer player;

        public override void OnStartLocalPlayer()
        {
            player = gameObject.GetComponent<ChromePlayer>();
            player.Setup();
        }
    }
}