package warden

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func allowedHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"allowed": false,
	})
}

func SetupRoutes(r *gin.Engine) {
	authorized := r.Group("", gin.BasicAuth(gin.Accounts{
		"foo":    "bar",
	}))

	authorized.POST("/allowed", allowedHandler)
}
