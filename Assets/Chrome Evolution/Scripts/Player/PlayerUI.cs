using UnityEngine;
using UnityEngine.UI;

using TMPro;

namespace ChromeEvo.Player
{
    public class PlayerUI : Runable
    {
        [SerializeField]
        private Slider sprintIndicator;
        [SerializeField]
        private Slider healthIndicator;
        [SerializeField]
        private TextMeshProUGUI clipAmmoText;
        [SerializeField]
        private TextMeshProUGUI totalAmmoText;

        private PlayerMovement movement;
        private PlayerStats stats;

        public override void Setup(params object[] _params)
        {
            movement = (PlayerMovement)_params[0];
            stats = (PlayerStats)_params[1];

            sprintIndicator.value = 1;
            healthIndicator.value = 1;

            RenderBulletCount(ref clipAmmoText, 50);
            RenderBulletCount(ref totalAmmoText, 100);
        }

        public override void Run(params object[] _params)
        {
            sprintIndicator.value = movement.SprintVisualFactor;
            healthIndicator.value = stats.HealthVisualFactor;
        }

        private void RenderBulletCount(ref TextMeshProUGUI _text, int _count)
        {
            _text.text = _count.ToString();
        }
    }
}