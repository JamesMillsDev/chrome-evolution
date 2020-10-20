using System;

using UnityEngine;
using UnityEngine.InputSystem;

namespace ChromeEvo
{
    public class InputUtils
    {
        public static InputAction FindAndEnable(ref PlayerInput _input, string _name)
        {
            InputAction action = _input.actions.FindAction(_name);
            action.Enable();
            return action;
        }

        public static void SubscribeEvents(ref InputAction _action, Action<InputAction.CallbackContext> _performed, Action<InputAction.CallbackContext> _canceled)
        {
            if(_performed != null)
            {
                _action.performed += _performed;
            }

            if(_canceled != null)
            {
                _action.canceled += _canceled;
            }
        }
    }
}