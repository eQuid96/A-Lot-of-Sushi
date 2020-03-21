using UnityEngine;

public class BackgroundMusicLoop : MonoBehaviour
{
    public AudioSource myAudio;
    [Range(0f, 26.5f)] // loops at 14.45-23.17
    public float loopStart, loopEnd;
    public GameObject player;
    
    private static BackgroundMusicLoop instance = null;
    private void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(this.gameObject);
        }
        else
        {
            instance = this;
        }

        DontDestroyOnLoad(this.gameObject);
    }

    void Start()
    {
        myAudio.Play();

    }

    void Update()
    {
        // TODO: put here
        if (myAudio.isPlaying && myAudio.time > loopEnd)
        {
            myAudio.time = loopStart;
        }

        if (player == null)
        {
            player = GameObject.Find("Player");

        }

        else
        {
            //check if the game is paused
            if (player.GetComponent<PlayerManager>().isPause)

            {
                myAudio.Pause();
            }

            //check if the game is resumed

            if (player.GetComponent<PlayerManager>().isPause == false)

            {
                myAudio.UnPause();

            }

        }

    }
}
