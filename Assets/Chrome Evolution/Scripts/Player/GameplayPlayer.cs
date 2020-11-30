using UnityEngine;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;
using ChromeEvo.Weapons;
using ChromeEvo.Networking;

namespace ChromeEvo.Player
{
    [RequireComponent(typeof(CapsuleCollider), typeof(Rigidbody))]
    public class GameplayPlayer : MonoBehaviour
    {
        private PlayerInput input;
        private new CapsuleCollider collider;
        private new Rigidbody rigidbody;

        private PlayerMovement movement;
        private new CameraController camera;
        private new PlayerRendering renderer;
        private PlayerUI ui;
        private PlayerStats stats;

        private bool isSetup = false;

        private PlayerNet playerNet;

        private void Awake()
        {
            input = FindObjectOfType<PlayerInput>();
            collider = gameObject.GetComponent<CapsuleCollider>();
            rigidbody = gameObject.GetComponent<Rigidbody>();

            rigidbody.constraints = RigidbodyConstraints.FreezeRotation;
        }

        public void Setup(PlayerNet _player)
        {
            playerNet = _player;

            // cache components in children
            RunableUtils.Validate(ref movement, gameObject);
            RunableUtils.Validate(ref camera, gameObject);
            RunableUtils.Validate(ref renderer, gameObject);
            RunableUtils.Validate(ref ui, gameObject);
            RunableUtils.Validate(ref stats, playerNet.gameObject);

            // setup runables
            RunableUtils.Setup(ref movement, input, rigidbody, collider, transform, camera);
            RunableUtils.Setup(ref camera, input, movement, transform);
            RunableUtils.Setup(ref renderer, input);
            RunableUtils.Setup(ref ui, movement, stats, playerNet);
            RunableUtils.Setup(ref stats);

            isSetup = true;
        }

        private void Update()
        {
            if(isSetup)
            {
                RunableUtils.Run(ref camera);
                RunableUtils.Run(ref renderer);
                RunableUtils.Run(ref ui);

                Weapon weapon = playerNet.GetWeapon();
                if (weapon != null)
                {
                    RunableUtils.Run(ref weapon);
                }
            }
        }

        private void FixedUpdate()
        {
            if(isSetup)
            {
                RunableUtils.Run(ref movement);
            }
        }
    }
}