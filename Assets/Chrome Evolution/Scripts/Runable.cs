using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ChromeEvo
{
    public abstract class Runable : MonoBehaviour
    {
        public abstract void Setup(params object[] _params);
        public abstract void Run(params object[] _params);
    }
}