using Sirenix.OdinInspector;

namespace ChromeEvo
{
    public abstract class Runable : SerializedMonoBehaviour, IRunable
    {
        public abstract void Setup(params object[] _params);
        public abstract void Run(params object[] _params);
    }
}