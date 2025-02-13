using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class incongruentScreenshot : MonoBehaviour
{
    public int count = 1;
    public GameObject Sphere3;
    private string name = System.Environment.UserName; //get the name of the current computer user

    // Start is called before the first frame update
    void Start()
    {
        ScreenCapture.CaptureScreenshot(@"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\Incongruent" + count + ".tiff"); //take screenshot
        InvokeRepeating("Screenshot", 1f, 1f);
    }

    void Screenshot()
    {
        count++; //increase count for filename

        ScreenCapture.CaptureScreenshot(@"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\Incongruent" + count + ".tiff"); //take screenshot

        Sphere3.transform.position = Sphere3.transform.position + new Vector3(-15f, 0f, 0f); //move right                                                                                      

    }
}
