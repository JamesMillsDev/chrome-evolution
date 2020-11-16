namespace ChromeEvo
{
    public interface IRunable
    {
        void Setup(params object[] _params);
        void Run(params object[] _params);
    }
}