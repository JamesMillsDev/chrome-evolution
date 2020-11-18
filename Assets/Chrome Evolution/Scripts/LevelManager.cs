using UnityEngine;
using UnityEngine.SceneManagement;

using ChromeEvo.Utils;

namespace ChromeEvo
{
    public class LevelManager : MonoBehaviour
    {
        public static LevelManager instance = null;

        private void Awake()
        {
            if(instance == null)
            {
                instance = this;
            }
            else if(instance != this)
            {
                Destroy(gameObject);
                return;
            }

            DontDestroyOnLoad(gameObject);
        }

        [SerializeField, SceneField]
        private string lobby = "";
        [SerializeField, SceneField]
        private string gameplay = "";

        public void LoadLobby()
        {
            SceneManager.LoadSceneAsync(lobby, LoadSceneMode.Additive);
        }

        public void LoadGameplay()
        {
            SceneManager.UnloadSceneAsync(lobby);
            SceneManager.LoadSceneAsync(gameplay, LoadSceneMode.Additive);
        }
    }
}