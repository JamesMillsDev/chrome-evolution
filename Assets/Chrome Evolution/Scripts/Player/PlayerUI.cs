using UnityEngine;
using UnityEngine.UI;

using TMPro;

using ChromeEvo.Weapons;
using ChromeEvo.Networking;

namespace ChromeEvo.Player
{
    #pragma warning disable 0649
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
        [SerializeField]
        private GameObject canvas;

        private PlayerMovement movement;
        private PlayerStats stats;
        private PlayerNet player;

        public override void Setup(params object[] _params)
        {
            canvas.SetActive(true);

            movement = (PlayerMovement)_params[0];
            stats = (PlayerStats)_params[1];
            player = (PlayerNet)_params[2];

            sprintIndicator.value = 1;
            healthIndicator.value = 1;

            RenderBulletCount(ref clipAmmoText, 50);
            RenderBulletCount(ref totalAmmoText, 100);
        }

        public override void Run(params object[] _params)
        {
            sprintIndicator.value = movement.SprintVisualFactor;
            healthIndicator.value = stats.HealthVisualFactor;

            Weapon weapon = player.GetWeapon();
            if (weapon != null)
            {
                clipAmmoText.text = weapon.ClipAmmo.ToString();
                totalAmmoText.text = weapon.TotalAmmo.ToString();
            }
        }

        private void RenderBulletCount(ref TextMeshProUGUI _text, int _count)
        {
            _text.text = _count.ToString();
        }
    }
}