using UnityEngine;

public class GrabInteraction : MonoBehaviour
{
    public bool isGrabbing;
    public Rigidbody _grabbedItem;
    private Vector3 _camOffset = new Vector3(0.0f, 0.0f, 1.0f);

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
                            isGrabbing = true;
                            _grabbedItem = hit.rigidbody;
                            hit.transform.position = Camera.main.transform.position + _camOffset;
                        }
                    }
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
                        if (Input.GetTouch(i).phase == TouchPhase.Moved)
                        {
                            /* TO DO THROW SUSHI */
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
