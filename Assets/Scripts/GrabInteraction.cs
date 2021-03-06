﻿using UnityEngine;
using UnityEngine.UI;

public class GrabInteraction : MonoBehaviour
{
    public bool isGrabbing;
    public Transform sushiAnchorPos;
    public Transform bacchette;
    private ThrowableObject _grabbedItem;
    public float throwForce;
    private const float MIN_THROW_FORCE = 1.0f, MAX_THROW_FORCE = 8.0f, THROW_CHARGE_SPEED = 8.0f;
    public GameObject throwBar;
    public Image throwSlider;
    private bool isDecreasing;

    private void Start()
    {
        RestThrowBar();
    }


    void Update()
    {
        if (PlayerManager.instance.isGameOver && PlayerManager.instance.isPause && PlayerManager.instance.isTimeOver)
        {
            return;
        }
#if UNITY_ANDROID
        AndroidUpdate();
#elif UNITY_WEBGL || UNITY_EDITOR
        GLUpdate();
#endif
    }

    void AndroidUpdate()
    {
        if (!isGrabbing)
        {
            Grab();
        }
        else
        {
            if (Input.touchCount > 0)
            {
                for (int i = 0; i < Input.touchCount; i++)
                {
                    if (isRightSide(Input.GetTouch(i).position))
                    {
                        if (Input.GetTouch(i).phase == TouchPhase.Began)
                        {
                            throwBar.SetActive(true);
                        }

                        if (Input.GetTouch(i).phase == TouchPhase.Stationary)
                        {
                            if (throwForce >= MAX_THROW_FORCE)
                            {
                                isDecreasing = true;
                            }

                            if (throwForce <= MIN_THROW_FORCE)
                            {
                                isDecreasing = false;
                            }

                            if (isDecreasing)
                            {
                                throwForce -= Time.deltaTime * THROW_CHARGE_SPEED;
                            }
                            else
                            {
                                throwForce += Time.deltaTime * THROW_CHARGE_SPEED;
                            }

                            throwSlider.fillAmount =
                                (throwForce - MIN_THROW_FORCE) / (MAX_THROW_FORCE - MIN_THROW_FORCE);
                        }

                        if (Input.GetTouch(i).phase == TouchPhase.Ended)
                        {
                            _grabbedItem.Throw(throwForce);
                            _grabbedItem = null;
                            isGrabbing = false;
                            RestThrowBar();
                        }
                    }
                }
            }
        }
    }

    void GLUpdate()
    {
        if (!isGrabbing)
        {
            Grab();
        }

        else
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                throwBar.SetActive(true);
            }

            if (Input.GetKey(KeyCode.Space))
            {
                if (throwForce >= MAX_THROW_FORCE)
                {
                    isDecreasing = true;
                }

                if (throwForce <= MIN_THROW_FORCE)
                {
                    isDecreasing = false;
                }

                if (isDecreasing)
                {
                    throwForce -= Time.deltaTime * THROW_CHARGE_SPEED;
                }
                else
                {
                    throwForce += Time.deltaTime * THROW_CHARGE_SPEED;
                }

                throwSlider.fillAmount = (throwForce - MIN_THROW_FORCE) / (MAX_THROW_FORCE - MIN_THROW_FORCE);
            }

            if (Input.GetKeyUp(KeyCode.Space))
            {
                _grabbedItem.Throw(throwForce);
                _grabbedItem = null;
                isGrabbing = false;
                RestThrowBar();
            }
        }
    }

    private void RestThrowBar()
    {
#if UNITY_ANDROID
        throwSlider.fillAmount = 0.0f;
        throwForce = MIN_THROW_FORCE;
        throwBar.SetActive(false);
#elif UNITY_WEBGL || UNITY_EDITOR
        throwSlider.fillAmount = 0.0f;
        throwForce = MIN_THROW_FORCE;
        throwBar.SetActive(false);
        isGrabbing = false;
#endif
    }

    private void Grab()
    {
#if UNITY_ANDROID
        if (Input.touchCount > 0)
        {
            for (int i = 0; i < Input.touchCount; i++)
            {
                if (Input.GetTouch(i).phase == TouchPhase.Began)
                {
                    // Construct a ray from the current touch coordinates
                    Ray ray = Camera.main.ScreenPointToRay(Input.GetTouch(i).position);
                    if (Physics.Raycast(ray, out RaycastHit hit))
                    {
                        // Grab game object with tab Grab
                        if (hit.transform.CompareTag("Grab"))
                        {
                            _grabbedItem = hit.transform.GetComponent<ThrowableObject>();
                            hit.transform.position = sushiAnchorPos.position;
                            hit.transform.parent = sushiAnchorPos.parent;
                        }
                    }
                }

                if (Input.GetTouch(i).phase == TouchPhase.Ended && _grabbedItem)
                {
                    isGrabbing = true;
                }
            }
        }
#elif UNITY_WEBGL || UNITY_EDITOR
        if (Input.GetMouseButtonDown(0))
        {
            // Construct a ray from the current touch coordinates
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                // Grab game object with tab Grab
                if (hit.transform.CompareTag("Grab"))
                {
                    _grabbedItem = hit.transform.GetComponent<ThrowableObject>();
                    hit.transform.position = sushiAnchorPos.position;
                    hit.transform.parent = sushiAnchorPos.parent;
                }
            }
        }

        if (Input.GetMouseButtonUp(0) && _grabbedItem)
        {
            if(_grabbedItem.transform.parent == sushiAnchorPos.parent)
            {
                isGrabbing = true;
            }
            
        }
#endif
    }

    // RETURN TRUE IF THE TOUCH INPUT IS ON THE RIGHT SIDE OF THE SCREEN
    private bool isRightSide(Vector2 input)
    {
        int rScreenResolution = Screen.width / 2;
        return input.x >= rScreenResolution ? true : false;
    }
}