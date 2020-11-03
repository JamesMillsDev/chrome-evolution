using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace ChromeEvo.Player
{
    public class PlayerUI : Runable
    {
        [SerializeField]
        private Slider sprintIndicator;

        private PlayerMovement movement;

        public override void Setup(params object[] _params)
        {
            movement = (PlayerMovement)_params[0];

            sprintIndicator.value = 1;
        }

        public override void Run(params object[] _params)
        {
            sprintIndicator.value = movement.SprintVisualFactor;
        }
    }
}