using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

using ChromeEvo.Utils;

namespace ChromeEvo.Player
{
    [RequireComponent(typeof(Camera))]
    public class CameraController : Runable
    {
        public bool Enabled { get { return true; } }

        [SerializeField, Range(0, 3)]
        private float sensitivity = 0.5f;
        [SerializeField, Range(0, 90)]
        private float verticalBounds = 90f;
        [SerializeField, Min(0.1f)]
        private float dampening = 1f;

        private PlayerInput input;
        private Transform playerTransform;
        private PlayerMovement movement;

        private new Camera camera;

        private InputAction lookAction;
        private Vector2 rotation;

        public override void Setup(params object[] _params)
        {
            input = (PlayerInput)_params[0];
            movement = (PlayerMovement)_params[1];
            playerTransform = (Transform)_params[2];

            // Get the camera component and enabled it
            camera = gameObject.GetComponent<Camera>();
            camera.enabled = true;

            // Disable the cursor
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;

            // Enable the look action
            InputUtils.CacheAndEnable(ref input, ref lookAction, "Look");

            // Store the current rotation of the player
            rotation = new Vector2(playerTransform.localEulerAngles.y, transform.localEulerAngles.x);
        }

        public override void Run(params object[] _params)
        {
            if(Enabled)
            {
                // Get the actual look movement from the input action
                Vector2 lookVector = lookAction.ReadValue<Vector2>();

                Vector2 old = rotation;

                // Apply the rotation to the vector and clamp the vertical
                rotation.x += lookVector.x * sensitivity;
                rotation.y += lookVector.y * sensitivity;
                rotation.y = Mathf.Clamp(rotation.y, -verticalBounds, verticalBounds);

                // Set the camera and player rotations to the calculated ones
                GetDampenedValues(out float xMovement, out float yMovement, old, rotation);
                transform.localRotation = Quaternion.AngleAxis(yMovement, Vector3.left);
                playerTransform.localRotation = Quaternion.AngleAxis(xMovement, Vector3.up);
            }
        }

        private void GetDampenedValues(out float _x, out float _y, Vector2 _old, Vector2 _new)
        {
            // Calculate the dampened x value by the delta between the old rotation and new rotation
            float xVelocity = (_old.x - rotation.x);
            _x = Mathf.SmoothDamp(_old.x, _new.x, ref xVelocity, dampening);

            // Calculate the dampened y value by the delta between the old rotation and new rotation
            float yVelocity = (_old.y - _new.y);
            _y = Mathf.SmoothDamp(_old.y, _new.y, ref yVelocity, dampening);
        }
    }
}