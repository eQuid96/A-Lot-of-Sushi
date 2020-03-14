using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class UIElements : MonoBehaviour
{
 
    private GameObject settings;
    private GameObject main;
    private GameObject overlay;

    void Start(){
        settings = transform.Find("SettingsMenu").gameObject;
        main = transform.Find("MainMenu").gameObject;
        overlay = transform.Find("Overlay").gameObject;
    }
 

    void Update(){
        
    }

    public void LoadScene(string name) {
        main.gameObject.SetActive(false);
        overlay.gameObject.SetActive(true);
        DontDestroyOnLoad(gameObject);
        SceneManager.LoadScene(name);
    }

    public void SwitchMenu(bool s) {
        if (s) {
            Debug.Log(settings);
            settings.SetActive(true);
            main.SetActive(false);
        }else{
            settings.SetActive(false);
            main.SetActive(true);
            if (SceneManager.GetActiveScene().name == "Game") {
                main.transform.Find("Image").gameObject.SetActive(false);
                main.transform.Find("Play").gameObject.GetComponentInChildren<TextMeshProUGUI>().text = "RESUME";
            }else {
                main.transform.Find("Play").gameObject.GetComponentInChildren<TextMeshProUGUI>().text = "PLAY";
            }
        }
    }

    public void TuneVolume(string name, float volume) {

    }

}
