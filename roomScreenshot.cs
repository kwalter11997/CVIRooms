using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class roomScreenshot : MonoBehaviour
{
    public int count = 1;
    public GameObject Sphere;
    private string name = System.Environment.UserName; //get the name of the current computer user

    void Start()
    {
        ScreenCapture.CaptureScreenshot(@"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\Room" + count + ".tiff"); //take screenshot
        InvokeRepeating("Screenshot", 1f, 1f);
    }

    void Screenshot()
    {
        count++; //increase count for filename

        ScreenCapture.CaptureScreenshot(@"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\Room" + count + ".tiff"); //take screenshot

        if ((count - 1) % 3 == 0)  //every 4th pic
        {
            Sphere.transform.position = Sphere.transform.position + new Vector3(-15f, 0f, 60f); //move right and back
        }

        else //go through rooms
        {
            Sphere.transform.position = Sphere.transform.position + new Vector3(0f, 0f, -30f); //move foward
        }

        //if (count == 60)
        //{
        //    Camera1.enabled = false; //turn off this camera
        //}
    }
}
