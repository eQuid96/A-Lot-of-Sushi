using UnityEngine;

public class GrabInteraction : MonoBehaviour
{
    public bool isGrabbing;
    public Transform sushiAnchorPos;
    public Transform bacchette;
    private Rigidbody _grabbedItem;
    private Vector2 touchStartPos, touchEndPos, touchDirection;
    private float touchTimeStart, touchTimeFinish, timeInterval;
    private float throwForceXY = 1.0f;
    private float throwForceZ = 30.0f;
    private const float MIN_TIME_SWIPE = 0.1f; // Swipe timer controll
    private Vector3 _camOffset = new Vector3(0.0f, 0.0f, 1.0f);
    void Update()
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
                            touchTimeStart = Time.time;
                            touchStartPos = Input.GetTouch(i).position;
                        }

                        if (Input.GetTouch(i).phase == TouchPhase.Stationary)
                        {
                            Debug.DrawRay(sushiAnchorPos.position, sushiAnchorPos.forward * 10.0f, Color.red);
                        }

                        if (Input.GetTouch(i).phase == TouchPhase.Ended)
                        {
                            touchTimeFinish = Time.time;
                            timeInterval = touchTimeFinish - touchTimeStart;

                            // Fast swipe is not allowed
                            if (timeInterval <= MIN_TIME_SWIPE)
                            {
                                return;
                            }

                            touchEndPos = Input.GetTouch(i).position;
                            touchDirection = touchStartPos - touchEndPos;
                            _grabbedItem.transform.parent = null;
                            _grabbedItem.isKinematic = false;
                            _grabbedItem.AddForce(-touchDirection.x * throwForceXY, -touchDirection.y * throwForceXY, throwForceZ / timeInterval);
                            _grabbedItem = null;
                            isGrabbing = false;
                        }
                    }
                }
            }
        }
    }

    private void Grab()
    {
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
                            _grabbedItem = hit.rigidbody;
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
    }
    // RETURN TRUE IF THE TOUCH INPUT IS ON THE RIGHT SIDE OF THE SCREEN
    private bool isRightSide(Vector2 input)
    {
        int r_screenResolution = Screen.width / 2;
        return input.x >= r_screenResolution ? true : false;
    }
}
