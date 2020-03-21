using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class PlayerManager : MonoBehaviour
{
    public int score = 0;
    public int life = 0;
    public bool isGameOver, isPause = true, isTimeOver;

    private float gameTimer = 0.0f;
    // UI
    public Text playerScore_txt;
    public Text timer_txt,winScore_txt;
    public GameObject pause_btn, pauseMenu;
    public GameObject[] lifesImg = new GameObject[MAX_PLAYER_LIFE];
    public GameObject win, loss;
    public NPCController waitress;

    // EVENTS
    public delegate void GameOver();
    public event GameOver onGameOver;

    // STATS
    private const int MAX_PLAYER_LIFE = 3;
    private const float MAX_GAME_TIMER = 60.0f; // GAME TIMER IN SECONDS

    public static PlayerManager instance = null;
    private GameObject sounds;

    private void Awake()
    {
        sounds = GameObject.Find("[Sounds Source]");
        if (!instance)
        {
            instance = this;
        }
    }

    void Start()
    {
        Time.timeScale = 0;
        isPause = false;
        score = 0;
        life = MAX_PLAYER_LIFE;
        gameTimer = MAX_GAME_TIMER;
        playerScore_txt.text = score.ToString();
    }

    private void Update()
    {
        if (isGameOver || isTimeOver)
        {
            Time.timeScale = 0;
            return;
        }

        if (!isTimeOver && !isPause)
        {
            if (gameTimer <= 0)
            {
                isTimeOver = true;
                gameTimer = 0;
                win.SetActive(true);
                winScore_txt.text = score.ToString();
                waitress.agent.isStopped = true;
                sounds.transform.Find("Win").GetComponent<AudioSource>().Play();
                waitress.transform.Find("OMEDETO").GetComponent<AudioSource>().Play();
            }

            gameTimer -= Time.deltaTime;
            UpdateTimerText();
        }
    }
    public void RemoveLife(int amount = 1)
    {
        int tmpLife = life - amount;

        if (tmpLife <= 0 && !isGameOver)
        {
            isGameOver = true;
            loss.SetActive(true);
            waitress.agent.isStopped = true;
            sounds.transform.Find("GameOver").GetComponent<AudioSource>().Play();
            waitress.transform.Find("DISGRACERU").GetComponent<AudioSource>().Play();
            life = 0;
            lifesImg[0].SetActive(false);
            return;
        }

        lifesImg[tmpLife].SetActive(false);
        life = tmpLife;
    }

    public void AddScore(int amount)
    {
        if (isGameOver)
        {
            return;
        }

        int tmpScore = score + amount;
        if (tmpScore >= int.MaxValue)
        {
            score = int.MaxValue;
            playerScore_txt.text = tmpScore.ToString();
            return;
        }
        score = tmpScore;
        playerScore_txt.text = tmpScore.ToString();
    }

    private void UpdateTimerText()
    {
        if (gameTimer <= 0)
        {
            timer_txt.text = "OVER";
            return;
        }
        int min = Mathf.FloorToInt(gameTimer / 60);
        int sec = Mathf.FloorToInt(gameTimer % 60);
        timer_txt.text = min.ToString("00") + ":" + sec.ToString("00");
    }

    public void Resume()
    {
        isPause = false;
        pause_btn.SetActive(true);
        pauseMenu.SetActive(false);
        Time.timeScale = 1;
    }

    public void Pause()
    {
        isPause = true;
        pause_btn.SetActive(false);
        pauseMenu.SetActive(true);
        Time.timeScale = 0;
    }

    public void Restart()
    {
        isPause = false;
        Time.timeScale = 1;
        SceneManager.LoadScene(0);
    }
}
