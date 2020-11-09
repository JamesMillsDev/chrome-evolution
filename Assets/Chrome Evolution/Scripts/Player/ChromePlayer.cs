using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;

namespace ChromeEvo.Player
{
    [RequireComponent(typeof(CapsuleCollider), typeof(Rigidbody))]
    public class ChromePlayer : MonoBehaviour
    {
        private PlayerInput input;
        private new CapsuleCollider collider;
        private new Rigidbody rigidbody;

        private PlayerMovement movement;
        private new CameraController camera;
        private new PlayerRendering renderer;
        private PlayerUI ui;

        private bool isSetup = false;

        public void Setup()
        {
            input = gameObject.GetComponentInChildren<PlayerInput>();
            collider = gameObject.GetComponent<CapsuleCollider>();
            rigidbody = gameObject.GetComponent<Rigidbody>();

            rigidbody.constraints = RigidbodyConstraints.FreezeRotation;

            // cache components in children
            RunableUtils.Validate(ref movement, gameObject);
            RunableUtils.Validate(ref camera, gameObject);
            RunableUtils.Validate(ref renderer, gameObject);
            RunableUtils.Validate(ref ui, gameObject);

            // setup runables
            RunableUtils.Setup(ref movement, input, rigidbody, collider, transform, camera);
            RunableUtils.Setup(ref camera, input, movement, transform);
            RunableUtils.Setup(ref renderer, input);
            RunableUtils.Setup(ref ui, movement);

            isSetup = true;
        }

        private void Start()
        {
            Setup();
        }

        private void Update()
        {
            if(isSetup)
            {
                RunableUtils.Run(ref camera);
                RunableUtils.Run(ref renderer);
                RunableUtils.Run(ref ui);
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