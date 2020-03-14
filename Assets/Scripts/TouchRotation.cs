using UnityEngine;

public class TouchRotation : MonoBehaviour
{
    private int screenWidth;
    private Vector3 _startTouch;
    private Vector3 _endTouch;
    private float xAngle = 0.0f;
    private float yAngle = 0.0f;
    private float xAngTemp = 0.0f;
    private float yAngTemp = 0.0f;
    private const float MIN_ROTATION_X = -90.0f;
    private const float MAX_ROTATION_X = 90.0f;
    private const float MIN_ROTATION_Y = -30.0f;
    private const float MAX_ROTATION_Y = 30.0f;
    private void Start()
    {
        //Initialization our angles of camera
        xAngle = 0.0f;
        yAngle = 0.0f;
        screenWidth = Screen.width;
        this.transform.rotation = Quaternion.Euler(yAngle, xAngle, 0.0f);
    }
    private void Update()
    {
        if (Input.touchCount > 0)
        {
            for (int i = 0; i < Input.touchCount; i++)
            {
                if (isLeftSide(Input.GetTouch(i).position))
                {
                    if (Input.GetTouch(i).phase == TouchPhase.Began)
                    {
                        _startTouch = Input.GetTouch(i).position;
                        xAngTemp = xAngle;
                        yAngTemp = yAngle;
                    }

                    //Move finger by screen
                    if (Input.GetTouch(i).phase == TouchPhase.Moved)
                    {
                        _endTouch = Input.GetTouch(i).position;
                        xAngle = xAngTemp + (_endTouch.x - _startTouch.x) * 180.0f / Screen.width;
                        yAngle = yAngTemp - (_endTouch.y - _startTouch.y) * 90.0f / Screen.height;
                        xAngle = Mathf.Clamp(xAngle, MIN_ROTATION_X, MAX_ROTATION_X);
                        yAngle = Mathf.Clamp(yAngle, MIN_ROTATION_Y, MAX_ROTATION_Y);
                        //Rotate camera
                        this.transform.rotation = Quaternion.Euler(yAngle, xAngle, 0.0f);
                    }
                }
            }
        }
    }

    // RETURN TRUE IF THE TOUCH INPUT IS ON THE LEFT SIDE OF THE SCREEN
    private bool isLeftSide(Vector2 input)
    {
        int leftSide = screenWidth / 2;
        return input.x <= leftSide ? true : false;
    }
}
