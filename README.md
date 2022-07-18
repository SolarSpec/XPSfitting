<div id="top"></div>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/SolarSpec/XPSfitting">
    <img src="XPS_Fitting_resources/logo.png" alt="SolarSpec" width="160" height="120">
  </a>

<h3 align="center">XPSfitting</h3>

  <p align="center">
    SolarSpec group script for fitting XPS data using a Shirley background
    <br />
    <a href="https://github.com/SolarSpec/XPSfitting"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/SolarSpec/XPSfitting">View Demo</a>
    ·
    <a href="https://github.com/SolarSpec/XPSfitting/issues">Report Bug</a>
    ·
    <a href="https://github.com/SolarSpec/XPSfitting/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

[![XPSfitting Screenshot][product-screenshot]](https://solarspec.ok.ubc.ca/)
Fitting XPS data using a Shirley background

<p align="right">(<a href="#top">back to top</a>)</p>

### Built With

* [MATLAB](https://www.mathworks.com/products/matlab.html)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To begin using this app is very simple. Just verify you have the necessary prequisites and follow the installation instructions.

### Prerequisites

Make sure MATLAB is installed. It is available for download in the Software Distribution section under the Help tab after you log into [Canvas.](https://canvas.ubc.ca/)
Click on the "Add-Ons" dropdown menu of your MATLAB Home screen. Then click on "Manage Add-Ons" and ensure you have the Image Processing Toolbox and the Signal Processing Toolbox. If not, click on the "Get Add-Ons" button instead and search for the aforementioned products.


### Installation

1. Clone the repo to your PC

   ```sh
   git clone https://github.com/SolarSpec/TaucPlotGUI.git
   ```

2. Now enter the repository and install the application in MATLAB

   ```
   Click on the .mlappinstall file in your repository
   ```

3. Browse the APPS header and click on the drop down.

   ```
   You will find the recently installed application under 'MY APPS' and can add it to your favourites
   ```

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

XPS is a technique using high energy light (X-rays) to eject electrons from a material. If one knows the energy of the X-ray, then on can determine how strongly the the released electron is bound to the core of the material. The fitted peaks tell the user about the center and relative energies of the material which can describe how many unique atoms are present in said material.

Begin by loading some XPS data in the form of an .ascii file. The user can either set the fit range by mouse or by keyboard (KBD) input using the respective "Set Fit Range" buttons, which will draw xlines on the specified x-coordinates. Next is to choose the type of background to set, either "Shirley BG" or "Linear BG" using the respective buttons which will actively iterate to find the Shirley Background or you can draw an ROI line between the ends of the peak regions for the Linear Background. The three edit fields below the Background axes allow the user to manually input the minimum and maximum values of the Linear background line and the tolerance value determines how much the slope change from the initial endpoints.

Next the user can click the "Select Initial Peaks" button to approximate the initial peaks of the loaded data by clicking the cursor on the "Initial Peak Positions" axes. When complete, the user can press enter to continue. Next determine the Full Width Half Max value (FWHM) by clicking on the "Generate Uniqueness Plot of FWHM" button, which uses a mix of Gaussian and Lorentz distributions (this app uses sum of each distribution instead of the product). The FWHM can also be constrained to a default value of +- 10% or any inputted percentage.

The Uniqueness plot generates the fit for all the FWHM values with the bounds and step inbetween. It outputs the Mean Squared Error (MSE) vs FWHM. The user can see where the fitting is best with the least amount of error and has the desired value outputted on the plot itself. Next, with this minimum error FWHM value, the user can enter this value back into the "FWHM +- X%" field and click the "Perform Fit" button for the best looking Fit Result plot.

After clicking "Perform Fit", the GUI gives the peak center and relative areas in percentage. Change the axes limits from the bottom left table, which only affects the Fit Result plot. The residuals are also plotted beneath the fit where the dashed line is effectively zero and the solid line is the difference between the original data and the calculated fit. You can shift it this object on the plot by editing the value beneath the Fit Results plot and clicking the "Shift" button. Export the fit results in the folder where the data was grabbed; the button returns a fit parameters file and an .emf figure of the Fit Result plot. The user can fit using previous settings if you open new but similar data by clicking the "Fit Using Previous Settings" button. This button saves the Fit Range bounds as well as the Inital Peak guesses and then reruns the same functions as before.

This app is currently lacking in any examples to be shown as it is still being created

_For more information on any of the internal functions, please refer to the [MATLAB Documentation](https://www.mathworks.com/help/matlab/)_

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

* [X] Plot XPS Intensity vs. Binding Energy (eV)
  * [X] Use the cursor to approximate initial peak positions
* [X] Set the fit range by keyboard or mouse input
* [X] Set either a Shirley or Linear background
* [X] Generate a Uniqueness Plot to determine the best FWHM value
* [X] Perform a Fit Results
  * [X] View residuals of data below results

</br>

See the [open issues](https://github.com/SolarSpec/XPSfitting/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the BSD 3-Clause License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

SolarSpec - [SolarSpec Website](https://solarspec.ok.ubc.ca/) - vidihari@student.ubc.ca

Project Link: [https://github.com/SolarSpec/XPSfitting](https://github.com/SolarSpec/XPSfitting)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Group Leader - Dr. Robert Godin](https://solarspec.ok.ubc.ca/people/)
* [Group Alumni - Jasper Pankratz](https://solarspec.ok.ubc.ca/people/)
* [The Entire SolarSpec Team](https://solarspec.ok.ubc.ca/people/)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/SolarSpec/XPSfitting.svg?style=for-the-badge
[contributors-url]: https://github.com/SolarSpec/XPSfitting/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/SolarSpec/XPSfitting.svg?style=for-the-badge
[forks-url]: https://github.com/SolarSpec/XPSfitting/network/members
[stars-shield]: https://img.shields.io/github/stars/SolarSpec/XPSfitting.svg?style=for-the-badge
[stars-url]: https://github.com/SolarSpec/XPSfitting/stargazers
[issues-shield]: https://img.shields.io/github/issues/SolarSpec/XPSfitting.svg?style=for-the-badge
[issues-url]: https://github.com/SolarSpec/XPSfitting/issues
[license-shield]: https://img.shields.io/github/license/SolarSpec/XPSfitting.svg?style=for-the-badge
[license-url]: https://github.com/SolarSpec/XPSfitting/blob/main/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/haris-vidimlic-06730019b/
[product-screenshot]: XPS_Fitting_resources/Screenshot.png
