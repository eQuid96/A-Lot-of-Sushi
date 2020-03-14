using UnityEngine;

public class GrabInteraction : MonoBehaviour
{
    public bool isGrabbing;
    public Transform sushiAnchorPos;
    public Rigidbody _grabbedItem;
    public Vector2 touchStartPos, touchEndPos, touchDirection;
    float touchTimeStart, touchTimeFinish, timeInterval;
    public float throwForceXY = 1.0f;
    public float throwForceZ = 50.0f;
    void Update()
    {
        if (!isGrabbing)
        {
            if (Input.touchCount > 0)
            {
                if (Input.GetTouch(0).phase == TouchPhase.Began)
                {
                    // Construct a ray from the current touch coordinates
                    Ray ray = Camera.main.ScreenPointToRay(Input.GetTouch(0).position);
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
                if (Input.GetTouch(0).phase == TouchPhase.Ended && _grabbedItem)
                {
                    isGrabbing = true;
                }
            }
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
                        if (Input.GetTouch(i).phase == TouchPhase.Ended)
                        {
                            touchTimeFinish = Time.time;
                            timeInterval = touchTimeFinish - touchTimeStart;
                            touchEndPos = Input.GetTouch(i).position;
                            touchDirection = touchStartPos - touchEndPos;
                            _grabbedItem.transform.parent = null;
                            _grabbedItem.isKinematic = false;
                            _grabbedItem.AddForce(-touchDirection.x * throwForceXY, -touchDirection.y * throwForceXY, throwForceZ / timeInterval);
                            isGrabbing = false;
                            _grabbedItem = null;
                        }
                    }
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
