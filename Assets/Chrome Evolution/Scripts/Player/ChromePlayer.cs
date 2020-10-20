using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace ChromeEvo.Player
{
    [RequireComponent(typeof(PlayerInput))]
    public class ChromePlayer : MonoBehaviour
    {
        private PlayerInput input;

        // Start is called before the first frame update
        void Start()
        {
            input = gameObject.GetComponent<PlayerInput>();
        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}