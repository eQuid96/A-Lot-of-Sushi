using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Audio;
public class UIMainMenu : MonoBehaviour
{
    public GameObject mainMenu, settingsMenu;
    public AudioMixer audioMixer;

    public void Play()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    public void SetAudioVolume(float value)
    {
        audioMixer.SetFloat("MusicVol", Mathf.Log10(value) * 20);
    }

    public void SwitchMenu(int type)
    {
        switch (type)
        {
            case 0:
                mainMenu.SetActive(true);
                settingsMenu.SetActive(false);
                break;
            case 1:
                mainMenu.SetActive(false);
                settingsMenu.SetActive(true);
                break;
            default:
                break;
        }
    }

}
