using UnityEngine;
using UnityEngine.UI;

public class PlayerManager : MonoBehaviour
{
    public int score = 0;
    public int life = 0;
    public bool isGameOver;

    // UI
    public Text playerScore_txt;

    // EVENTS
    public delegate void GameOver();
    public event GameOver onGameOver;

    // STATS
    private const int MAX_PLAYER_LIFE = 3;

    public static PlayerManager instance = null;

    private void Awake()
    {
        if (!instance)
        {
            instance = this;
        }
    }

    void Start()
    {
        score = 0;
        life = MAX_PLAYER_LIFE;
        playerScore_txt.text = score.ToString();
    }

    public void RemoveLife(int amount = 1)
    {
        int tmpLife = life - amount;

        if (tmpLife <= 0 && !isGameOver)
        {
            isGameOver = true;
            onGameOver?.Invoke(); // SEND GAME OVER EVENT
            tmpLife = 0;
            return;
        }

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
}
