using UnityEngine;
[RequireComponent(typeof(GrabInteraction))]
public class ThrowInteraction : MonoBehaviour
{
    private const float MIN_DISTANCE = 300.0f;
    private GrabInteraction grabInteraction;
    private float startTime, endTime;
    private Vector3 startPosition, endPosition;

    void Start()
    {
        grabInteraction = GetComponent<GrabInteraction>();
    }

    void Update()
    {
        if (grabInteraction.isGrabbing)
        {
            for (int i = 0; i < Input.touchCount; i++)
            {
                Touch input = Input.GetTouch(i);
                if (input.phase == TouchPhase.Began && isThrowArea(input.position))
                {
                    startTime = Time.time;
                    startPosition = input.position;
                }
                if (input.phase == TouchPhase.Ended && isThrowArea(input.position))
                {
                    endTime = Time.time;
                    endPosition = input.position;
                    float distance = Vector3.Distance(startPosition, endPosition);
                    float timeDifference = endTime - startTime;
                    if (distance > MIN_DISTANCE)
                    {
                        grabInteraction.Throw(timeDifference);
                    }
                }
            }
        }
    }

    // RETURN TRUE IF THE TOUCH INPUT IS ON THE RIGHT SIDE OF THE SCREEN
    private bool isThrowArea(Vector2 input)
    {
        int screenThrowArea = Screen.height / 6;
        return input.y >= screenThrowArea ? true : false;
    }
}
